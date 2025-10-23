"use client";

import { useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { sendEmailResetPassword } from "@/hooks/use-user";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import ErrorMessage from "@/components/@shared/error-message.component";
import { toast } from "sonner";

export default function ResetPassword() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    try {
      setError("");
      const emailRegex = /^[\w._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/i;

      if (!emailRegex.test(email.trim())) {
        setError("Email inválido");
        return;
      }

      await sendEmailResetPassword(email);
      toast.success("Email enviado!");
    } catch {
      toast.error("Houve algum erro inesperado.");
    }
  };

  return (
    <div className="flex flex-col justify-center h-screen items-center">
      <Card className="flex text-white border-card">
        <CardHeader>
          <CardTitle>Redefinir senha</CardTitle>
          <CardDescription>
            Informe seu email para redefinir sua senha. Um email será enviado a
            sua caixa de entrada.
          </CardDescription>
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
              <Label>Email</Label>
              <Input
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="border-gray-700 focus-visible:ring-card focus:!border-background"
                size={40}
              />
            </div>
            <div className="flex justify-end">
              <Button type="submit" className="w-auto cursor-pointer">
                Enviar
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
