"use client";

import { useSearchParams } from "next/navigation";
import { Button } from "@/components/ui/button";
import { useRouter } from "next/navigation";
import { confirmRegister } from "@/hooks/use-user";
import { toast } from "sonner";

export default function ConfirmRegister() {
  const searchParams = useSearchParams();
  const token = searchParams.get("token");
  const router = useRouter();

  const handleSubmit = async () => {
    try {
      if (!token) {
        throw Error;
      }

      const data = await confirmRegister(token);

      if (!data.success) {
        throw Error;
      }

      toast.success("Conta confirmada com sucesso!");
      router.push("/auth/login");
    } catch {
      toast.error("Houve algum problema no servidor");
    }
  };

  return (
    <div className="flex flex-col items-center gap-2 justify-center h-screen text-white">
      <h1 className="text-2xl">Confirme a criação da sua conta.</h1>
      <Button onClick={handleSubmit} className="cursor-pointer">
        Confirmar
      </Button>
    </div>
  );
}
