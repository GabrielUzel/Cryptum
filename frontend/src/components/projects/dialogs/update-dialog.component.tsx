import { useState, useEffect } from "react";
import ErrorMessage from "../../@shared/error-message.component";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogFooter, DialogClose } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { AxiosError } from "axios";
import { toast } from "sonner"

type UpdateProjectDialogProps = {
  initialName: string;
  initialDescription: string;
  open: boolean;
  setOpen: (open: boolean) => void;
  projectId: string | null;
  onUpdate: (projectId: string, name?: string, description?: string, setDialogError?: (error: string | null) => void) => void;
};

export default function UpdateProjectDialog(
  props: UpdateProjectDialogProps
) {
  const { open, setOpen, projectId, onUpdate, initialName, initialDescription } = props;
  const [name, setName] = useState(initialName);
  const [description, setDescription] = useState(initialDescription);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (open) {
      setName(initialName);
      setDescription(initialDescription);
    }
  }, [open, initialName, initialDescription]);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    setError(null);

    if (!projectId) {
      return;
    }

    try {
      await onUpdate(projectId, name, description, setError);

      setOpen(false);
      resetFields();
    } catch(error: unknown) {
      if (error instanceof AxiosError && error.response?.status === 400) {
        setError("Este nome pertence a um projeto que já existe ou os campos são inválidos.");
        return;
      }

      toast.error("Erro ao criar arquivo", {
        description: "Tente novamente mais tarde."
      });
    }    
  };

  const resetFields = () => {
    setName("");
    setDescription("");
    setError(null);
  };

  const handleOpenChange = (isOpen: boolean) => {
    if (!isOpen) {
      resetFields();
    }

    setOpen(isOpen);
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="text-white flex flex-col gap-3 border-card" onOpenAutoFocus={event => event.preventDefault()}>
        <DialogHeader>
          <DialogTitle>Atualizar projeto</DialogTitle>
          <DialogDescription>Atualize o nome e a descrição do projeto.</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="flex flex-col gap-8">
          <div className="flex flex-col gap-4">
            {error ? 
              <ErrorMessage direction="row" message={error} textsize="text-sm" /> : 
              <span className="h-10"></span>
            }
            <Input
              placeholder="Nome do projeto"
              value={name}
              onChange={e => setName(e.target.value)}
              className="border-card focus-visible:ring-card focus:!border-card"
            />
            <Textarea
              placeholder="Descrição"
              value={description}
              onChange={e => setDescription(e.target.value)}
              className="border-card focus-visible:ring-card focus:!border-card"
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