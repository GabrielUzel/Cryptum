import { UserGateway } from '@/api/auth/user.gateway';
import { AxiosError } from 'axios';
import { useQuery } from '@tanstack/react-query'; 

const userGateway = new UserGateway();

interface LoginBody {
  email: string;
  password: string;
}

interface RegisterBody {
  name: string;
  email: string;
  password: string;
}

export const useUser = async () => {
  try {
    const data = await userGateway.getUser();
    return data;
  } catch (error) {
    throw error;
  }
};

export function useLogin() {
  const login = async (
    body: LoginBody,
    {
      onSuccess,
      onError,
    }: {
      onSuccess?: (data: unknown) => void;
      onError?: (error: Error) => void;
    } = {}
  ) => {
    try {
      const data = await userGateway.login(body.email, body.password);
      onSuccess?.(data);
    } catch (error) {
      let reason: string = "";

      if (error && typeof error === "object" && "isAxiosError" in error) {
        const axiosError = error as AxiosError<{ error: string }>;

        if(axiosError.response?.data?.error) {
          reason = "Email ou senha incorretos";
        } else {
          reason = "Houve um erro no servidor, tente novamente mais tarde.";
        }
      }

      onError?.(new Error(reason));
    }
  };

  return { login };
}

export const logout = async () => {
  try {
    const data = await userGateway.logout();
    return data;
  } catch (error) {
    throw error;
  }
}

export const useRegister = () => {
  const register = async (
    body: RegisterBody,
    {
      onSuccess,
      onError,
    }: {
      onSuccess?: (data: unknown) => void;
      onError?: (errors: { error: string; field: string; }[]) => void;
    } = {}
  ) => {
    try {
      const data = await userGateway.register(body.name, body.email, body.password);
      onSuccess?.(data);
    } catch (error) {
      if (error && typeof error === "object" && "isAxiosError" in error) {
        const errorTranslations: Record<string, string> = {
          "Email format invalid": "Formato de email inválido",
          "Email already registered": "Email já cadastrado",
          "Password must contain at least one number": "A senha deve conter pelo menos um número",
          "Password must be at least 8 characters long": "A senha deve ter pelo menos 8 caracteres",
        };

        const axiosError = error as AxiosError<{ errors?: { error: string; field: string }[]; error?: string }>;
        const translatedMessages = axiosError.response?.data.errors?.map(msg => ({
          error: errorTranslations[msg.error] || msg.error,
          field: msg.field
        }));

        onError?.(translatedMessages ?? []);
      }
    }
  };

  return { register };
}

export const useGetUser = () => {
  return useQuery({
    queryKey: ['getUser'], 
      queryFn: async () => {
      try {
        const data = await userGateway.getUser();
        return data;
      } catch (error) {
        throw error;
      }
    }, 
  });
}
