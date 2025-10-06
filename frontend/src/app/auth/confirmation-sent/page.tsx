import { Button } from "@/components/ui/button";
import Image from "next/image";
import Link from "next/link";

export default function ConfirmationSent() {
  return(
    <div className="flex flex-col items-center gap-2 justify-center h-screen text-white">
      <h1 className="text-2xl">Um email foi enviado a sua caixa de entrada!</h1>
      <p>Autorize sua conta para poder utilizar o site.</p>
      <Link href="/auth/login">
        <Button className="w-full flex items-center cursor-pointer justify-center gap-2">
          <Image
            src="/left-icon.svg"
            alt="Botão de voltar à página de login"
            width={20}
            height={20}
          />
          Página de login
        </Button>
      </Link>
    </div>
  );
}