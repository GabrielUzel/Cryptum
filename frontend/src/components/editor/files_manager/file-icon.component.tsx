import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import Image from "next/image";

const maxNameLength = 15;

interface FileIconProps {
  fileName: string
  fileSize: string
  removeFile: () => void
}

export default function FileIcon(
  props: FileIconProps
) {
  const { fileName, fileSize, removeFile } = props;
  const nameToDisplay = fileName.length > maxNameLength ? fileName.slice(0, maxNameLength) + "..." : fileName;

  return (
    <Card className="p-2 pl-4 group text-white border-card">
      <div className="flex justify-between items-center">
        <div className="flex gap-4 items-center">
          <Image
            src="/default-file-icon.svg"
            alt="Arquivo"
            width={20}
            height={20}
          />
          <p className="text-sm truncate max-w-[150px]" title={fileName}>
            {nameToDisplay}
          </p>
        </div>
        <div className="flex items-center gap-4">
          <p className="text-sm w-16 text-right">
            {fileSize} KB
          </p>
          <Button 
            className="hover:bg-transparent cursor-pointer shadow-none bg-transparent p-1 w-fit h-fit opacity-0 group-hover:opacity-100 transition-opacity" 
            onClick={removeFile}
          >
            <Image
              src="/close-icon.svg"
              alt="Remover arquivo"
              width={15}
              height={15}
            />
          </Button>
        </div>
      </div>
    </Card>
  );
}
