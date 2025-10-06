import { useState } from "react";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogFooter, DialogClose } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";

type ShareProjectDialogProps = {
  open: boolean;
  setOpen: (open: boolean) => void;
  projectId: string | null;
  onShare: (projectId: string, email: string, role: string) => void;
};

// TODO: Seleção de role
export default function ShareProjectDialog(
  props: ShareProjectDialogProps
) {
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("guest");
  const { open, setOpen, projectId, onShare } = props;

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent className="text-white flex flex-col gap-16 border-card">
        <div className="flex flex-col gap-8">
          <DialogHeader className="text-white">
            <DialogTitle>Compartilhar projeto</DialogTitle>
            <DialogDescription>Envie um convite para o email desejado</DialogDescription>
          </DialogHeader>
          <div className="flex flex-col gap-2">
            <Label>
              Email
            </Label>
            <Input
              className="border-card focus-visible:ring-card focus:!border-card"
              id="email"
              name="email"
              size={40}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
        </div>
        <DialogFooter>
          <Button
            type="button"
            onClick={() => {
              if (projectId) {
                onShare(projectId, email, role);
                setOpen(false);
              }
            }}
            className="!bg-primary hover:!bg-primary/60 cursor-pointer"
          >
            Compartilhar
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