import { useState } from "react";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogFooter, DialogClose } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";

type UpdateProjectDialogProps = {
  open: boolean;
  setOpen: (open: boolean) => void;
  projectId: string | null;
  onUpdate: (projectId: string, name: string, description: string) => void;
};

export default function UpdateProjectDialog(
  props: UpdateProjectDialogProps
) {
  const { open, setOpen, projectId, onUpdate } = props;
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    
    if (projectId) {
      onUpdate(projectId, name, description);
    }
    
    resetFields();
    setOpen(false);
  };

  const resetFields = () => {
    setName("");
    setDescription("");
  };

  const handleOpenChange = (isOpen: boolean) => {
    if (!isOpen) {
      resetFields();
    }

    setOpen(isOpen);
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="text-white flex flex-col gap-8 border-card">
        <DialogHeader>
          <DialogTitle>Atualizar projeto</DialogTitle>
          <DialogDescription>Atualize o nome e a descrição do projeto.</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="flex flex-col gap-8">
          <div className="flex flex-col gap-4">
            <Input
              placeholder="Nome do projeto"
              value={name}
              onChange={e => setName(e.target.value)}
              required
              className="border-card"
            />
            <Textarea
              placeholder="Descrição"
              value={description}
              onChange={e => setDescription(e.target.value)}
              className="border-card"
              rows={4}
              maxLength={300}
            />
          </div>
          <DialogFooter>
            <Button type="submit" className="!bg-primary hover:!bg-primary/60 cursor-pointer">
              Atualizar
            </Button>
            <DialogClose asChild>
              <Button
                type="button"
                variant="ghost"
                className="!bg-card hover:!bg-card/60 hover:!text-white cursor-pointer"
                onClick={resetFields}
              >
                Cancelar
              </Button>
            </DialogClose>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}