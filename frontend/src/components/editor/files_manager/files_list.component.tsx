import { useGetFiles } from "@/hooks/use-files";
import FileCard from "./file-card.component";

type FilesListProps = {
  projectId: string;
  onSelectFile: (fileId: string, filename: string) => void;
  currentFileId: string | null;
  onFileDeleted: (deletedFileId: string) => void;
};

type File = {
  id: string;
  filename: string;
};

export default function FilesList(props: FilesListProps) {
  const { projectId, onSelectFile, currentFileId, onFileDeleted } = props;
  const { data } = useGetFiles(projectId);

  return (
    <section>
      <ul>
        {data?.map((file: File) => {
          const parts = file.filename.split(".");
          const extension = parts.length > 1 ? (parts.pop() ?? "") : "";
          const fullName = file.filename;

          return (
            <FileCard
              key={file.id}
              projectId={projectId}
              fileId={file.id}
              fileName={fullName}
              fileExtension={extension}
              onClick={() => onSelectFile(file.id, file.filename)}
              isSelected={currentFileId === file.id}
              onFileDeleted={onFileDeleted}
            />
          );
        })}
      </ul>
    </section>
  );
}
