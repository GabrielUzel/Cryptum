import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogClose,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

type DeleteFileDialogProps = {
  open: boolean;
  setOpen: (open: boolean) => void;
  onDelete: () => void;
};

export default function DeleteFileDialog(props: DeleteFileDialogProps) {
  const { open, setOpen, onDelete } = props;

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent className="text-white flex flex-col gap-16 border-card">
        <DialogHeader className="text-white">
          <DialogTitle>Excluir Arquivo</DialogTitle>
          <DialogDescription>
            Tem certeza que deseja excluir este arquivo?
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button
            type="button"
            onClick={() => {
              onDelete();
              setOpen(false);
            }}
            className="!bg-primary hover:!bg-primary/60 cursor-pointer"
          >
            Excluir
          </Button>
          <DialogClose asChild>
            <Button
              type="button"
              variant="ghost"
              className="!bg-card hover:!bg-card/60 hover:!text-white cursor-pointer"
            >
              Cancelar
            </Button>
          </DialogClose>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
