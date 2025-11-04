import { Suspense } from "react";
import ConfirmInvitationContent from "@/components/projects/project-invitation-content";
import LoadingSpinner from "@/components/@shared/loading-spinner";

export default function ConfirmInvitation() {
  return (
    <Suspense
      fallback={
        <div className="flex flex-col items-center justify-center min-h-screen gap-4 text-center text-white">
          <div className="flex flex-col justify-center items-center gap-2">
            <LoadingSpinner />
            <h1 className="text-xl">Carregando...</h1>
          </div>
        </div>
      }
    >
      <ConfirmInvitationContent />
    </Suspense>
  );
}
