import NewFileDialog from "./new-file-dialog.component";
import FilesList from "./files_list.component";

type FilesManagerProps = {
  projectId: string;
  onSelectFile: (fileId: string) => void;
  currentFileId: string | null;
  setFileIsEditable: (isEditable: boolean) => void;
  onFileDeleted: (deletedFileId: string) => void;
};

export default function FilesManager(props: FilesManagerProps) {
  const {
    projectId,
    onSelectFile,
    currentFileId,
    setFileIsEditable,
    onFileDeleted,
  } = props;

  const checkIfFileIsEditable = (filename: string): boolean => {
    const extension = filename.split(".").pop()?.toLowerCase();
    return extension === "tex";
  };

  const handleSelectFile = (fileId: string, filename: string) => {
    onSelectFile(fileId);
    const isEditable = checkIfFileIsEditable(filename);
    setFileIsEditable(isEditable);
  };

  return (
    <section className="bg-card rounded-lg">
      <div className="bg-primary relative flex p-2 items-center rounded-tl-lg rounded-tr-lg">
        <NewFileDialog projectId={projectId} />
      </div>
      <FilesList
        projectId={projectId}
        onSelectFile={handleSelectFile}
        currentFileId={currentFileId}
        onFileDeleted={onFileDeleted}
      />
    </section>
  );
}
