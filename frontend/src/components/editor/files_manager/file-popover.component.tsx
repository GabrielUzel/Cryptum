import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Button } from "@/components/ui/button";

type FilesPopoverProps = {
  downloadAction: () => void;
  renameAction: () => void;
  deleteAction: () => void;
}

export default function FilePopover(
  props: FilesPopoverProps
) {
  const { downloadAction, renameAction, deleteAction } = props;

  return(
    <Popover>
      <PopoverTrigger className="cursor-pointer w-2 h-2 flex items-center justify-center">
        <span className="flex flex-col gap-1 space-x-1 p-2">
          <span className="w-[4px] h-[4px] bg-white rounded-full"></span>
          <span className="w-[4px] h-[4px] bg-white rounded-full"></span>
          <span className="w-[4px] h-[4px] bg-white rounded-full"></span>
        </span> 
      </PopoverTrigger>
      <PopoverContent className="flex flex-col gap-1 bg-background text-white border-card">
        <div className="flex flex-col gap-2">
          <Button 
            variant={"ghost"} 
            className="hover:bg-card hover:text-white cursor-pointer w-full h-full p-2 m-0 rounded-sm justify-start"
            onClick={() => downloadAction()}
          >
            Baixar
          </Button>
          <Button 
            variant={"ghost"} 
            className="hover:bg-card hover:text-white cursor-pointer w-full h-full p-2 m-0 rounded-sm justify-start"
            onClick={() => renameAction()}
          >
            Renomear
          </Button>
          <Button 
            variant={"ghost"} 
            className="hover:bg-card hover:text-white cursor-pointer w-full h-full p-2 m-0 rounded-sm justify-start"
            onClick={() => deleteAction()}
          >
            Excluir
          </Button>
        </div>
      </PopoverContent>
    </Popover>
  );
}