"use client";

import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { toast } from "sonner";
import { confirmInvitation } from "@/hooks/use-project-members";
import { logout } from "@/hooks/use-user";
import LoadingSpinner from "@/components/@shared/loading-spinner";
import { AxiosError } from "axios";
import { Button } from "@/components/ui/button";

type InvitationState =
  | "loading"
  | "success"
  | "wrong_user"
  | "not_authorized"
  | "invalid";

export default function ConfirmInvitationContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get("token");
  const [state, setState] = useState<InvitationState>("loading");

  useEffect(() => {
    const handleInvitation = async () => {
      if (!token) {
        setState("invalid");
        return;
      }

      try {
        await confirmInvitation(token);
        setState("success");
        toast.success("Você foi adicionado ao projeto com sucesso!");
        router.push("/");
      } catch (error: unknown) {
        if (error instanceof AxiosError) {
          switch (error.response?.status) {
            case 400:
              setState("invalid");
              break;
            case 401:
              router.push(
                `/auth/login?redirect=/project/invitation?token=${token}`,
              );
              break;
            case 403:
              setState("wrong_user");
              break;
          }
        }
      }
    };

    handleInvitation();
  }, [token, router]);

  const backToLogin = () => {
    logout();
    router.push(`/auth/login?redirect=/project/invitation?token=${token}`);
  };

  const renderPage = () => {
    if (state === "loading") {
      return (
        <div className="flex flex-col justify-center items-center gap-2">
          <LoadingSpinner />
          <h1 className="text-xl">Processando convite</h1>
        </div>
      );
    }

    if (state === "wrong_user") {
      return (
        <div className="flex flex-col justify-center items-center gap-2">
          <h1 className="text-xl">
            Conta logada não corresponde a conta do convite.
          </h1>
          <Button onClick={backToLogin} className="cursor-pointer">
            Ir para login
          </Button>
        </div>
      );
    }

    if (state === "not_authorized") {
      return (
        <div className="flex flex-col justify-center items-center gap-2">
          <h1 className="text-xl">Login necessário</h1>
          <p>Você precisa estar logado para aceitar o convite.</p>
          <Button onClick={backToLogin} className="cursor-pointer">
            Ir para login
          </Button>
        </div>
      );
    }

    if (state === "success") {
      return (
        <div className="flex flex-col justify-center items-center gap-2">
          <h1 className="text-xl">
            Você foi adicionado ao projeto com sucesso!
          </h1>
        </div>
      );
    }

    return (
      <div className="flex flex-col justify-center items-center gap-2">
        <h1 className="text-2xl">Erro!</h1>
        <p>Houve algum erro, tente novamente mais tarde.</p>
      </div>
    );
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen gap-4 text-center text-white">
      {renderPage()}
    </div>
  );
}
