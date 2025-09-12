import { useState } from "react";
import Link from "next/link";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import TablePopover from './table-popover.component';
import UpdateProjectDialog from "./dialogs/update-dialog.component";
import DeleteProjectDialog from "./dialogs/delete-dialog.component";
import ShareProjectDialog from "./dialogs/share-dialog.component";
import ManageMembersDialog from "./dialogs/manage-members-dialog";

type Project = {
  id: string;
  name: string;
  description: string;
}

type ProjectsTableProps = {
  data:Project[];
};

export default function ProjectsTable(
  props: ProjectsTableProps
) {
  const [openUpdate, setOpenUpdate] = useState(false);
  const [openDelete, setOpenDelete] = useState(false);
  const [openShare, setOpenShare] = useState(false);
  const [openMembers, setOpenMembers] = useState(false);
  const [selectedProjectId, setSelectedProjectId] = useState<string | null>(null);
  const { data } = props;

  const openUpdateDialog = (projectId: string) => {
    setSelectedProjectId(projectId);
    setOpenUpdate(true);
  }

  const openDeleteDialog = (projectId: string) => {
    setSelectedProjectId(projectId);
    setOpenDelete(true);
  }

  const openShareDialog = (projectId: string) => {
    setSelectedProjectId(projectId);
    setOpenShare(true);
  }

  const openManageMembersDialog = (projectId: string) => {
    setSelectedProjectId(projectId);
    setOpenMembers(true);
  }

  const onUpdate = (projectId: string, name: string, description: string) => {
    // Chama hook para atualizar o projeto
    console.log(projectId, name, description);
  }

  const onDelete = (projectId: string) => {
    // Chama hook para deletar o projeto
    console.log(projectId);
  }

  const onShare = (projectId: string) => {
    // Chama hook para compartilhar o projeto
  }

  const onManageMembers = (projectId: string) => {
    // Chama hook para gerenciar os membros do projeto
  }

  return (
    <>
      <Table className="[&>tbody>tr]:border-b-2 [&>tbody>tr]:border-card">    
        <TableHeader>
          <TableRow className="hover:bg-secondary">
            <TableHead className="text-white p-5 border-b-2 border-card">Nome</TableHead>
            <TableHead className="text-white p-5 border-b-2 border-card">Descrição</TableHead>
            <TableHead className="text-white p-5 border-b-2 border-card"><span></span></TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
            {data?.map((project: Project) => (
            <TableRow key={project.id} className="hover:bg-secondary">
              <TableCell className="p-0">
                <Link key={project.id} href={`/projects/${project.id}`} className="block w-full h-full p-5">
                  {project.name}
                </Link>
              </TableCell>
              <TableCell className="p-0">
                <Link key={project.id} href={`/projects/${project.id}`} className="block w-full h-full p-5">
                  <Tooltip>
                    <TooltipTrigger>
                      {project.description.length > 30
                        ? project.description.slice(0, 30) + '...'
                        : project.description}
                    </TooltipTrigger>
                    <TooltipContent className="bg-background">
                      {project.description}
                    </TooltipContent>
                  </Tooltip>
                </Link>
              </TableCell>
              <TableCell className="p-5">
                <TablePopover 
                  projectId={project.id}
                  updateAction={openUpdateDialog}
                  deleteAction={openDeleteDialog}
                  shareAction={openShareDialog}
                  manageMembersAction={openManageMembersDialog}
                />
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      <UpdateProjectDialog
        open={openUpdate}
        setOpen={setOpenUpdate}
        projectId={selectedProjectId}
        onUpdate={onUpdate}
      />
      <DeleteProjectDialog
        open={openDelete}
        setOpen={setOpenDelete}
        projectId={selectedProjectId}
        onDelete={onDelete}
      />
      {/* <ShareProjectDialog
        open={openShare}
        setOpen={setOpenShare}
        projectId={selectedProjectId}
      />
      <ManageMembersDialog
        open={openMembers}
        setOpen={setOpenMembers}
        projectId={selectedProjectId}
      /> */}
    </>
  );
}