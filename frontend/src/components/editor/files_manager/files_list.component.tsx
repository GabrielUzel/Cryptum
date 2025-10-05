import { useGetFiles } from "@/hooks/use-files";
import FileCard from "./file-card.component";

type FilesListProps = {
  projectId: string
}

type File = {
  id: string,
  filename: string
}

export default function FilesList(
  props: FilesListProps
) {
  const { projectId } = props;
  const { data } = useGetFiles(projectId);

  return(
    <section>
      <ul>
        {data?.map((file: File) => {
          const parts = file.filename.split(".");
          const extension = parts.length > 1 ? parts.pop() ?? "" : "";
          const fullName = file.filename;

          return (
            <FileCard
              key={file.id}
              projectId={projectId}
              fileId={file.id}
              fileName={fullName}
              fileExtension={extension}
            />
          );
        })}
      </ul>
    </section>
  );
}