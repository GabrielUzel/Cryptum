import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import ErrorMessage from "../../@shared/error-message.component";
import { Button } from "@/components/ui/button";
import Image from "next/image";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
  DialogClose,
  DialogDescription,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { createFile } from "@/hooks/use-files";
import { AxiosError } from "axios";
import UploadFile from "./upload-file.component";

const REQUIRED_EXTENSION = ".tex";
const DEFAULT_NAME = "novo_arquivo";

type NewFileDialogProps = {
  projectId: string;
};

export default function NewFileDialog(props: NewFileDialogProps) {
  const { projectId } = props;
  const [open, setOpen] = useState(false);
  const [fileName, setFileName] = useState(DEFAULT_NAME + REQUIRED_EXTENSION);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<"new" | "upload">("new");
  const buttonSelectedStyle = "bg-card";
  const buttonNotSelectedStyle = "bg-transparent";

  const queryClient = useQueryClient();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const baseName = fileName.replace(REQUIRED_EXTENSION, "").trim();

    if (!baseName) {
      setError("Nome é obrigatório");
      return;
    }

    if (!fileName.endsWith(REQUIRED_EXTENSION)) {
      setError("Extensão do arquivo deve ser .tex");
      return;
    }

    try {
      await createFile(projectId, fileName);
      queryClient.invalidateQueries({ queryKey: ["getFiles"] });
      toast.success("Arquivo criado!");
      resetFields();
      setOpen(false);
    } catch (error: unknown) {
      if (error instanceof AxiosError && error.response?.status === 400) {
        setError("Este nome pertence a um arquivo que já existe.");
        return;
      }

      toast.error("Erro ao criar arquivo", {
        description: "Tente novamente mais tarde.",
      });
    }
  };

  const resetFields = () => {
    setFileName(DEFAULT_NAME + REQUIRED_EXTENSION);
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
      <DialogTrigger asChild>
        <Button className="cursor-pointer hover:brightness-150 p-2">
          <Image
            src="/add-file-icon.svg"
            alt="Image de um arquivo"
            width={20}
            height={20}
          ></Image>
        </Button>
      </DialogTrigger>
      <DialogContent className="border-card text-white flex gap-8">
        <div className="flex flex-col gap-4">
          <Button
            onClick={() => setActiveTab("new")}
            className={`w-full cursor-pointer hover:bg-card ${activeTab === "new" ? buttonSelectedStyle : buttonNotSelectedStyle}`}
          >
            Novo arquivo
          </Button>
          <Button
            onClick={() => setActiveTab("upload")}
            className={`w-full cursor-pointer hover:bg-card ${activeTab === "upload" ? buttonSelectedStyle : buttonNotSelectedStyle}`}
          >
            Upload
          </Button>
        </div>
        <div className="flex flex-col gap-8 ">
          {activeTab === "new" ? (
            <div>
              <DialogHeader>
                <DialogTitle>Criar novo arquivo</DialogTitle>
                <DialogDescription>Digite o nome do arquivo.</DialogDescription>
              </DialogHeader>
              <form onSubmit={handleSubmit} className="flex flex-col gap-8">
                <div className="flex flex-col gap-8">
                  {error ? (
                    <ErrorMessage
                      direction="row"
                      message={error}
                      textsize="text-sm"
                    />
                  ) : (
                    <span className="h-5"></span>
                  )}
                  <div className="flex flex-col gap-2">
                    <Label>Nome do arquivo</Label>
                    <Input
                      placeholder=""
                      value={fileName}
                      onChange={(e) => setFileName(e.target.value)}
                      className="border-card focus-visible:ring-card focus:!border-card"
                      size={40}
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button
                    type="submit"
                    className="!bg-primary hover:!bg-primary/60 cursor-pointer"
                  >
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
            </div>
          ) : (
            <UploadFile projectId={projectId} />
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
