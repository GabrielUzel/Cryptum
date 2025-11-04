import { Suspense } from "react";
import ConfirmRegisterContent from "@/components/auth/register-content.component";

export default function ConfirmRegister() {
  return (
    <Suspense
      fallback={
        <div className="flex flex-col items-center gap-2 justify-center h-screen text-white">
          <h1 className="text-2xl">Carregando...</h1>
        </div>
      }
    >
      <ConfirmRegisterContent />
    </Suspense>
  );
}
