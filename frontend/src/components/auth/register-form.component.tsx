import { useState } from "react";
import { useRouter } from "next/navigation";
import ErrorMessage from "../@shared/error-message.component";
import { Input } from "../ui/input";
import { Button } from "../ui/button";
import { Label } from "../ui/label";
import { useRegister } from "@/hooks/use-user";
import SeePassword from "./see-password.component";

export default function RegisterForm() {
  const router = useRouter();
  const [errors, setErrors] = useState<{ [key: string]: string }>({});
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);
  const [isConfirmPasswordVisible, setIsConfirmPasswordVisible] = useState(false);

  const { 
    register,
  } = useRegister();

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const name = (event.currentTarget.elements.namedItem("name") as HTMLInputElement).value;
    const email = (event.currentTarget.elements.namedItem("email") as HTMLInputElement).value;
    const password = (event.currentTarget.elements.namedItem("password") as HTMLInputElement).value;
    const confirm_password = (event.currentTarget.elements.namedItem("confirm_password") as HTMLInputElement).value;

    const newErrors: { [key: string]: string } = {};

    if (!name.trim()) {
      newErrors.name = "Nome é obrigatório";
    }

    if (!email.trim()) {
      newErrors.email = "Email é obrigatório";
    }

    if (!password.trim()) {
      newErrors.password = "Senha é obrigatória";
    }

    if (password !== confirm_password) {
      newErrors.confirm_password = "As senhas não são iguais";
    }

    setErrors(newErrors);

    if (Object.keys(newErrors).length > 0) {
      return;
    }

    register({ name, email, password }, {
      onSuccess: () => {
        router.push("/auth/login");
      },
      onError: (errors: { error: string; field: string; }[]) => {
        const apiErrors: { [key: string]: string } = {};

        errors.forEach(({ error, field }) => {
          switch (field) {
            case "email":
              apiErrors.email = error;
              break;
            case "name":
              apiErrors.name = error;
              break;
            case "password":
              apiErrors.password = error;
              break;
          }
        });

        setErrors(apiErrors);
      }
    });
  };

  return (
    <form className="flex flex-col gap-4" onSubmit={handleSubmit}>
      {errors.api ? 
        <ErrorMessage direction="row" message={errors.api} textsize="text-sm" /> : 
        <span className="h-5"></span>
      }
      <div className="flex flex-col gap-2">
        <div className="flex justify-between">
          <Label htmlFor="name">Nome</Label>
          {errors.name ? (
            <ErrorMessage direction="row" message={errors.name} textsize="text-sm" />
          ) : (
            <span className="h-5" />
          )}
        </div>
        <Input 
          className="border-card focus-visible:ring-card focus:!border-card"
          id="name" 
          name="name" 
          size={40} 
        />
      </div>
      <div className="flex flex-col gap-2">
        <div className="flex justify-between">
          <Label htmlFor="email">Email</Label>
          {errors.email ? (
            <ErrorMessage direction="row" message={errors.email} textsize="text-sm" />
          ) : (
            <span className="h-5" />
          )}
        </div>
        <Input 
          className="border-card focus-visible:ring-card focus:!border-card"
          id="email" 
          name="email" 
          size={40} 
        />
      </div>
      <div className="flex flex-col gap-2 relative">
        <div className="flex justify-between">
          <Label htmlFor="password">Senha</Label>
          {errors.password ? (
            <ErrorMessage direction="row" message={errors.password} textsize="text-sm" />
          ) : (
            <span className="h-5" />
          )}
        </div>
        <div>
          <Input 
            className="border-card focus-visible:ring-card focus:!border-card"
            type={isPasswordVisible ? "text" : "password"} 
            id="password"
            size={40}
          />
          <div className="absolute inset-y-11.5 right-2 flex items-center">
            <SeePassword
              isVisible={isPasswordVisible}
              onToggle={(event) => {
                event.preventDefault();
                setIsPasswordVisible(!isPasswordVisible);
              }}
            />
          </div>
        </div>
      </div>
      <div className="flex flex-col gap-2 relative">
        <div className="flex justify-between">
          <Label htmlFor="confirm_password">Confirmar senha</Label>
          {errors.confirm_password ? (
            <ErrorMessage direction="row" message={errors.confirm_password} textsize="text-sm" />
          ) : (
            <span className="h-5" />
          )}
        </div>
        <div>
          <Input
            className="border-card focus-visible:ring-card focus:!border-card"
            type={isConfirmPasswordVisible ? "text" : "password"}
            id="confirm_password"
            size={40} 
          />
          <div className="absolute inset-y-11.5 right-2 flex items-center">
            <SeePassword
              isVisible={isConfirmPasswordVisible}
              onToggle={(event) => {
                event.preventDefault();
                setIsConfirmPasswordVisible(!isConfirmPasswordVisible);
              }}
            />
          </div>
        </div>
      </div>
      <Button className="cursor-pointer" type="submit" variant="default">Criar conta</Button>
    </form>
  );
}
