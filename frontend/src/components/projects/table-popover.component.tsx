import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Button } from '../ui/button';
import Image from "next/image";
import { Separator } from "../ui/separator";

type TablePopoverProps = {
  projectId: string;
  updateAction: (projectId: string) => void;
  deleteAction: (projectId: string) => void;
  shareAction: (projectId: string) => void;
  manageMembersAction: (projectId: string) => void;
};

export default function TablePopover(
  props: TablePopoverProps
) {
  const { projectId, updateAction, deleteAction, shareAction, manageMembersAction } = props;

  return (
    <Popover>
      <PopoverTrigger className="cursor-pointer w-8 h-8 flex items-center justify-center">
        <span className="flex space-x-1">
          <span className="w-1 h-1 bg-white rounded-full"></span>
          <span className="w-1 h-1 bg-white rounded-full"></span>
          <span className="w-1 h-1 bg-white rounded-full"></span>
        </span> 
      </PopoverTrigger>
      <PopoverContent className="flex flex-col gap-1 bg-background text-white border-card">
        <p className="text-sm font-bold py-2 px-1">
          Ações
        </p>

        <Separator className="bg-card"/>

        <div className="flex flex-col gap-2">
          <Button 
            variant={"ghost"} 
            className="hover:bg-card hover:text-white cursor-pointer w-full h-full p-2 m-0 rounded-sm justify-start"
            onClick={() => updateAction(projectId)}
          >
            <Image 
              src="/refresh-icon.svg" 
              alt="Atualizar ícone" 
              width={16} 
              height={16} 
            />
            Atualizar
          </Button>
          <Button 
            variant={"ghost"} 
            className="hover:bg-card hover:text-white cursor-pointer w-full h-full p-2 m-0 rounded-sm justify-start"
            onClick={() => deleteAction(projectId)}
          >
            <Image 
              src="/trash-icon.svg" 
              alt="Atualizar ícone" 
              width={16} 
              height={16} 
            />
            Excluir
          </Button>
          <Button 
            variant={"ghost"} 
            className="hover:bg-card hover:text-white cursor-pointer w-full h-full p-2 m-0 rounded-sm justify-start"
            onClick={() => shareAction(projectId)}
          >
            <Image 
              src="/share-icon.svg" 
              alt="Compartilhar ícone" 
              width={16} 
              height={16} 
            />
            Compartilhar
          </Button>
          <Button 
            variant={"ghost"} 
            className="hover:bg-card hover:text-white cursor-pointer w-full h-full p-2 m-0 rounded-sm justify-start"
            onClick={() => manageMembersAction(projectId)}
          >
            <Image
              src="/users-icon.svg"
              alt="Gerenciar membros ícone"
              width={16}
              height={16}
            />
            Gerenciar membros
          </Button>
        </div>
      </PopoverContent>
    </Popover>
  );
}