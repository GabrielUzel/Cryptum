"use client";

import { useSearchParams, useRouter } from "next/navigation";
import { useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { resetPassword } from "@/hooks/use-user";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import SeePassword from "@/components/auth/see-password.component";
import ErrorMessage from "@/components/@shared/error-message.component";
import { toast } from "sonner";

export default function ResetPasswordConfirmation() {
  const searchParams = useSearchParams();
  const token = searchParams.get("token");
  const [password, setPassword] = useState("");
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);
  const [error, setError] = useState("");
  const router = useRouter();

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    try {
      setError("");

      if (!password.trim()) {
        setError("Senha é obrigatória");
        return;
      }

      if (password.length < 8) {
        setError("A senha deve ter pelo menos 8 caracteres");
        return;
      }

      if (!/\d/.test(password)) {
        setError("A senha deve conter pelo menos um número");
        return;
      }

      if (!token) {
        throw Error;
      }

      await resetPassword(password, token);
      toast.success("Senha modificada!");
      router.push("/auth/login");
    } catch {
      toast.error("Houve algum erro inesperado.");
    }
  };

  return (
    <div className="flex flex-col justify-center h-screen items-center">
      <Card className="flex text-white border-card">
        <CardHeader>
          <CardTitle>Redefinir senha</CardTitle>
          <CardDescription>Informe sua nova senha.</CardDescription>
        </CardHeader>
        <CardContent>
          <form className="flex flex-col gap-4" onSubmit={handleSubmit}>
            {error ? (
              <ErrorMessage
                direction="row"
                message={error}
                textsize="text-sm"
              />
            ) : (
              <span className="h-5"></span>
            )}
            <div className="flex flex-col gap-2">
              <Label>Senha</Label>
              <div>
                <Input
                  className="border-gray-700 focus-visible:ring-card focus:!border-background"
                  type={isPasswordVisible ? "text" : "password"}
                  id="password"
                  name="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  size={40}
                />
                <div className="absolute inset-y-129.5 right-195 flex items-center">
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
            <div className="flex justify-end">
              <Button type="submit" className="w-auto cursor-pointer">
                Redefinir
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
