"use client"

import Link from "next/link";
import LoginForm from "@/components/auth/login-form.component";
import { Card, CardContent } from "@/components/ui/card";

export default function Login() {
  return(
    <div className="flex items-center justify-center min-h-screen bg-primary">
      <Card className="flex items-center gap-4 p-10">
        <div className="flex flex-col items-center gap-2">
          <h1 className="text-4xl font-bold">Login</h1>
          <p className="text-gray-500 text-lg">Faça login para continuar</p>
        </div>
        <CardContent className="flex flex-col gap-4">
          <LoginForm />
          <div>
            <p className="text-gray-500 text-sm">
              Não é cadastrado?{" "}
              <Link href="/auth/register" className="text-blue-500">
                Crie uma conta
              </Link>
            </p>
            <p className="text-gray-500 text-sm">
              <Link href="/auth/reset-password" className="text-blue-500">
                Esqueci minha senha
              </Link>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}