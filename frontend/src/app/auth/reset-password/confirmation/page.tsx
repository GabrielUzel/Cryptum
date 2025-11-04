import { Suspense } from "react";
import ResetPasswordConfirmationContent from "@/components/auth/confirm-reset-password-content.component";
import { Card, CardContent } from "@/components/ui/card";

export default function ResetPasswordConfirmation() {
  return (
    <Suspense
      fallback={
        <div className="flex flex-col justify-center h-screen items-center">
          <Card className="flex text-white border-card">
            <CardContent className="p-6">
              <div>Carregando...</div>
            </CardContent>
          </Card>
        </div>
      }
    >
      <ResetPasswordConfirmationContent />
    </Suspense>
  );
}
