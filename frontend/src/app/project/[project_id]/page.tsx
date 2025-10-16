"use client"

import { getProjectInfo } from "@/hooks/use-projects";
import { useParams } from "next/navigation";
import { useEffect, useState } from "react";
import ProjectMenubar from "@/components/editor/menubar/menubar.component";
import FilesManager from "@/components/editor/files_manager/files_manager.component";
import ColaborativeEditor from "@/components/editor/colaborative_editor/colaborative_editor.component";
import Compiler from "@/components/editor/compiler/compiler.component";
import { ClientOnly } from "@/utils/client-only.handler";

interface Project {
  name: string;
  description: string;
}

export default function ProjectPage() {
  const params = useParams();
  const project_id = params.project_id as string;
  const [currentFileId, setCurrentFileId] = useState<string | null>(null);
  const [data, setData] = useState<Project | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      const projectData = await getProjectInfo(project_id);
      setData(projectData);
    };

    fetchData();
  }, [project_id]);

  return (
    <div className="flex flex-col gap-4 text-white h-screen">
      <ProjectMenubar title={data?.name} />
      <div className="flex flex-1 gap-4 mx-4 mb-4">
        <FilesManager projectId={project_id} onSelectFile={setCurrentFileId} />
        <ClientOnly>
          {currentFileId ? 
            <ColaborativeEditor fileId={currentFileId} /> : 
            <div className="flex-[2] bg-card p-4 rounded-lg">
              <p className="text-center text-muted-foreground mt-20">Selecione um arquivo para editar</p>
            </div>
          }
        </ClientOnly>
        <Compiler />
      </div>
    </div>
  );
}