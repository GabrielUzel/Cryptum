import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogFooter, DialogClose } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

type DeleteProjectDialogProps = {
  open: boolean;
  setOpen: (open: boolean) => void;
  projectId: string | null;
  onDelete: (projectId: string) => void;
};

export default function DeleteProjectDialog(
  props: DeleteProjectDialogProps
) {
  const { open, setOpen, projectId, onDelete } = props;

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent className="text-white flex flex-col gap-16 border-card">
        <DialogHeader className="text-white">
          <DialogTitle>Excluir projeto</DialogTitle>
          <DialogDescription>Tem certeza que deseja excluir este projeto?</DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button
            type="button"
            onClick={() => {
              if (projectId) {
                onDelete(projectId);
                setOpen(false);
              }
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