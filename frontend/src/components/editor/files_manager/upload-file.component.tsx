import { useState, useCallback } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import FileIcon from "./file-icon.component";
import { uploadFiles } from "@/hooks/use-files";
import { toast } from "sonner";

const REQUIRED_EXTENSIONS = [".tex", ".pdf"];

type UploadFilesProps = {
  projectId: string;
}

export default function UploadFilesArea(
  props: UploadFilesProps
) {
  const { projectId } = props;
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
  const [isDragging, setIsDragging] = useState(false);
  const queryClient = useQueryClient();

  const removeFile = (fileName: string) => {
    setSelectedFiles(prev => prev.filter(file => file.name !== fileName));
  }

  const processFiles = useCallback((files: FileList | null) => {
    if (!files) {
      return;
    }

    const validFiles: File[] = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const extension = `.${file.name.split(".").pop()?.toLowerCase()}`;

      if (!REQUIRED_EXTENSIONS.includes(extension)) {
        toast.error("Apenas arquivos .tex e .pdf são permitidos.");
        continue;
      }

      const isDuplicate = selectedFiles.some(
        existingFile => existingFile.name === file.name
      );

      if (isDuplicate) {
        toast.error(`Este arquivo já foi adicionado`);
        continue;
      }

      validFiles.push(file);
    }

    if (validFiles.length === 0) {
      return;
    }

    setSelectedFiles(prev => [...prev, ...validFiles]);
  }, [selectedFiles]);

  const handleFileChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    processFiles(e.target.files);
    if (e.target.files) e.target.value = "";
  }, [processFiles]);

  const handleDragOver = useCallback((e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(true);
  }, []);

  const handleDragLeave = useCallback((e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(false);
  }, []);

  const handleDrop = useCallback((e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(false);
    processFiles(e.dataTransfer.files);
  }, [processFiles]);

  const handleUploadSubmit = async () => {
    if (selectedFiles.length === 0) {
      toast.error("Selecione pelo menos um arquivo antes de enviar");
      return;
    }

    if (selectedFiles.length > 3) {
      toast.error("Você pode enviar no máximo 3 arquivos por vez");
      return;
    }

    await uploadFiles(projectId, selectedFiles); 
    console.log("Arquivos selecionados para envio:", selectedFiles);

    toast.success("Arquivos adicionados com sucesso!");
    queryClient.invalidateQueries({queryKey: ['getFiles']});
    setSelectedFiles([]);
  }

  return (
    <div className="flex flex-col gap-4">
      <h1>Upload de arquivo</h1>
      <div 
        className={`border-2 border-dashed rounded-lg p-10 text-center cursor-pointer transition-colors ${
          isDragging 
            ? "border-primary bg-primary/10" 
            : "border-muted-foreground/30 hover:border-muted-foreground/50"
        }`}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        onClick={() => document.getElementById("fileInput")?.click()}
      >
        <p className="text-gray-400 text-sm">
          Arraste seus arquivos (.tex ou .pdf) para esta área ou clique para selecionar
        </p>
      </div>
      <input
        type="file"
        id="fileInput"
        accept=".tex,.pdf"
        className="hidden"
        multiple
        onChange={handleFileChange}
      />
      <div className="flex flex-col gap-2">
        {selectedFiles.map(file => (
          <FileIcon
            key={file.name}
            fileName={file.name}
            fileSize={(file.size / 1024).toFixed(2)}
            removeFile={() => removeFile(file.name)}
          />
        ))}
      </div>
      <div className="flex justify-end">
        <Button onClick={handleUploadSubmit} className="w-fit cursor-pointer">
          Enviar
        </Button>
      </div>
    </div>
  );
}
