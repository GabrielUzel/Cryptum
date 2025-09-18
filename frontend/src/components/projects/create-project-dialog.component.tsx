"use client";

import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogClose } from "@/components/ui/dialog";
import { Button } from "../ui/button";
import { Input } from "../ui/input";
import { Textarea } from "../ui/textarea";
import { DialogDescription } from "@radix-ui/react-dialog";

type CreateProjectDialogProps = {
  open: boolean;
  setOpen: (open: boolean) => void;
  onCreate: (name: string, description: string) => void;
};

export default function CreateProjectDialog(
  props: CreateProjectDialogProps
) {
  const { open, setOpen, onCreate } = props;
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    onCreate(name, description);
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
          <DialogTitle>Criar novo projeto</DialogTitle>
          <DialogDescription>Insira o nome e a descrição do projeto.</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="flex flex-col gap-8">
          <div className="flex flex-col gap-4">
            <Input
              placeholder="Nome do projeto"
              value={name}
              onChange={e => setName(e.target.value)}
              required
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
              Criar
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
