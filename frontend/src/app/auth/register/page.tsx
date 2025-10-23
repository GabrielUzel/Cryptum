"use client";

import RegisterForm from "@/components/auth/register-form.component";
import { Card, CardContent } from "@/components/ui/card";
import { ClientOnly } from "@/utils/client-only.handler";

export default function Register() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-background">
      <Card className="flex items-center gap-4 p-10 border-none text-white">
        <div className="flex flex-col items-center gap-2">
          <h1 className="text-4xl font-bold">Criar conta</h1>
        </div>
        <CardContent>
          <ClientOnly>
            <RegisterForm />
          </ClientOnly>
        </CardContent>
      </Card>
    </div>
  );
}
