import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogClose,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

type RenameFileDialogProps = {
  initialFileName: string;
  open: boolean;
  setOpen: (open: boolean) => void;
  onRename: (fileName: string) => void;
};

export default function RenameFileDialog(props: RenameFileDialogProps) {
  const { initialFileName, open, setOpen, onRename } = props;
  const [fileName, setFileName] = useState(initialFileName);

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();

    onRename(fileName);

    resetFields();
    setOpen(false);
  };

  const resetFields = () => {
    setFileName("");
  };

  const handleOpenChange = (isOpen: boolean) => {
    if (!isOpen) {
      resetFields();
    }

    setOpen(isOpen);
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent
        className="text-white flex flex-col gap-8 border-card"
        onOpenAutoFocus={(event) => event.preventDefault()}
      >
        <DialogHeader>
          <DialogTitle>Renomear arquivo</DialogTitle>
          <DialogDescription>Atualize o nome do arquivo.</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="flex flex-col gap-8">
          <div className="flex flex-col gap-4">
            <Input
              value={fileName}
              onChange={(e) => setFileName(e.target.value)}
              className="border-card focus-visible:ring-card focus:!border-card"
            />
          </div>
          <DialogFooter>
            <Button
              type="submit"
              className="!bg-primary hover:!bg-primary/60 cursor-pointer"
            >
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
