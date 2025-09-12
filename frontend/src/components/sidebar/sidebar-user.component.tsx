import Image from "next/image";
import Link from "next/link";
import { DropdownMenu, DropdownMenuTrigger, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator } from "../ui/dropdown-menu";
import { Button } from "../ui/button";
import { logout } from "@/hooks/use-user";

type SidebarUserProps = {
  name: string;
};

export default function SidebarUser(
  props: SidebarUserProps
) {
  const { name } = props;

  const handleLogout = async (event: React.MouseEvent<HTMLButtonElement>) => {
    try {
      console.log("Logging out...");
      event.preventDefault();
      await logout();
      window.location.href = "/";
    } catch (error) {
      console.error(error);
    }
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger className="flex gap-2 p-4 border-t border-card cursor-pointer focus:outline-none hover:bg-primary rounded-xl">
        <Image
          src="user-icon.svg"
          alt="User image"
          width={24}
          height={24}
          className="rounded-full"
        />
        <p>{name}</p>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="bg-backgrond border-card">
        <DropdownMenuItem className="text-white m-0 p-0 data-[highlighted]:bg-primary data-[highlighted]:text-white">
          <Link href="/profile" className="hover:bg-primary cursor-pointer w-full h-full p-2 rounded-sm">
            Perfil
          </Link>
        </DropdownMenuItem>
        <DropdownMenuItem className="text-white m-0 p-0 data-[highlighted]:bg-primary data-[highlighted]:text-white">
          <Link href="/settings" className="hover:bg-primary cursor-pointer w-full h-full p-2 rounded-sm">
            Configurações
          </Link>
        </DropdownMenuItem>
        <DropdownMenuSeparator className="bg-card"/>
        <DropdownMenuItem className="text-white m-0 p-0 data-[highlighted]:bg-card">
          <Button 
            onClick={(event) => handleLogout(event)} 
            variant="ghost" 
            className="hover:bg-primary hover:text-white cursor-pointer w-full h-full p-2 m-0 rounded-sm justify-start"
          >
            Sair
          </Button>
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
