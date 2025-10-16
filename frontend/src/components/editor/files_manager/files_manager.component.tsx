import NewFileDialog from "./new-file-dialog.component";
import FilesList from "./files_list.component";

type FilesManagerProps = {
  projectId: string
  onSelectFile: (fileId: string) => void;
}

export default function FilesManager(
  props: FilesManagerProps
) {
  const { projectId, onSelectFile } = props;

  return (
    <section className="flex-1 bg-card rounded-lg">
      <div className="bg-primary relative flex p-2 items-center rounded-tl-lg rounded-tr-lg">
        <NewFileDialog projectId={projectId}/>
      </div>
      <FilesList projectId={projectId} onSelectFile={onSelectFile}/>
    </section>
  );
}