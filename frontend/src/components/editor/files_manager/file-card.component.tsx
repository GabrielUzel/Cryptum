import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { Card } from "@/components/ui/card";
import Image from "next/image";
import FilePopover from "./file-popover.component";
import { toast } from "sonner";
import { downloadFile } from "@/hooks/use-files";
import RenameFileDialog from "./rename-file-dialog.component";
import DeleteFileDialog from "./delete-file-dialog.component";
import { renameFile, deleteFile } from "@/hooks/use-files";

type FileCardProps = {
  projectId: string;
  fileId: string;
  fileName: string;
  fileExtension: string;
}

export default function FileCard(
  props: FileCardProps
) {
  const { projectId, fileId, fileName, fileExtension } = props;
  const [openRename, setOpenRename] = useState(false);
  const [openDelete, setOpenDelete] = useState(false);

  const queryClient = useQueryClient();

  const getFileIcon = (extension: string) => {
    switch (extension.toLowerCase()) {
      case "pdf":
        return "/pdf-file-icon.svg";
      case "tex":
        return "/tex-file-icon.svg";
      default:
        return "/default-file-icon.svg";
    }
  }

  const openRenameDialog = () => {
    setOpenRename(true);
  }

  const openDeleteDialog = () => {
    setOpenDelete(true);
  }

  const onDownload = async () => {
    try {
      const blob = await downloadFile(projectId, fileId);
      const url = window.URL.createObjectURL(new Blob([blob]));
      const link = document.createElement("a");

      link.href = url;
      link.setAttribute("download", fileName);
      
      document.body.appendChild(link);

      link.click();
      link.parentNode?.removeChild(link);
    } catch {
      toast.error("Houve um erro ao baixar o arquivo")
    }
  }

  const onRename = async (fileName: string) => {
    try {
      await renameFile(projectId, fileId, fileName);
      toast.success("Arquivo renomeado com sucesso!");
      setOpenRename(false);
      queryClient.invalidateQueries({ queryKey: ['getFiles'] });
    } catch {
      toast.error("Houve um erro ao renomear o arquivo");
    }
  }

  const onDelete = async () => {
    try {
      await deleteFile(projectId, fileId);
      queryClient.invalidateQueries({ queryKey: ['getFiles'] });
      toast.success("Arquivo excluído com sucesso!");
    } catch {
      toast.error("Houve algum erro, tente novamente mais tarde.");
    }
  }

  return(
    <>
      <Card className="flex flex-row items-center justify-between p-3 border-none shadow-none bg-card hover:brightness-150 cursor-pointer rounded-none">
        <div className="flex gap-3">
          <div className="w-5 h-5 relative">
            <Image
              src={getFileIcon(fileExtension)}
              alt={`Ícone do arquivo ${fileExtension}`}
              fill
              style={{ objectFit: "contain" }}
            />
          </div>
          <p className="text-white">{fileName}</p>
        </div>
        <div>
          <FilePopover downloadAction={onDownload} renameAction={openRenameDialog} deleteAction={openDeleteDialog}/>
        </div>
      </Card>
      <RenameFileDialog open={openRename} setOpen={setOpenRename} onRename={onRename} initialFileName={fileName}/>
      <DeleteFileDialog open={openDelete} setOpen={setOpenDelete} onDelete={onDelete} />
    </>
  );
}