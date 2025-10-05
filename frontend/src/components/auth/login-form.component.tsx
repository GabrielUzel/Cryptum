import { useState } from "react";
import { useRouter } from "next/navigation";
import ErrorMessage from "../@shared/error-message.component";
import { Input } from "../ui/input";
import { Button } from "../ui/button";
import { Label } from "../ui/label";
import { useLogin } from "@/hooks/use-user";
import SeePassword from "./see-password.component";

export default function LoginForm() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const { 
    login,
  } = useLogin();

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (!email || !password) {
      setError("Email e senha são obrigatórios");
      return;
    }

    login({ email, password }, {
      onSuccess: () => {
        router.push("/");
      },
      onError: (error: Error) => {
        setError(error.message);
      }
    });
  };

  return (
    <form className="flex flex-col gap-4" onSubmit={handleSubmit}>
      {error ? 
        <ErrorMessage direction="row" message={error} textsize="text-sm" /> : 
        <span className="h-5"></span>
      }
      <div className="flex flex-col gap-2">
        <Label htmlFor="email">Email</Label>
        <Input
          className="border-background focus-visible:ring-card focus:!border-background"
          id="email"
          name="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          size={40}
        />
      </div>
      <div className="flex flex-col gap-2 relative">
        <Label htmlFor="password">Senha</Label>
        <div>
        <Input 
          className="border-background focus-visible:ring-card focus:!border-background"
          type={isPasswordVisible ? "text" : "password"} 
          id="password"
          name="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          size={40}
        />
          <div className="absolute inset-y-10 right-2 flex items-center">
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
      <Button className="cursor-pointer" type="submit" variant="default">Login</Button>
    </form>
  );
}
