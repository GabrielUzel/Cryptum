import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
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
import { deleteProject, updateProject } from "@/hooks/use-projects";
import { getProjectMembers, shareProject, manageProjectMembers } from "@/hooks/use-project-members";
import { toast } from "sonner";

type Project = {
  id: string;
  name: string;
  description: string;
}

type ProjectMember = {
  project_id: string;
  id: string;
  role: string;
  name: string;
};

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
  const [members, setMembers] = useState<ProjectMember[]>([]);
  const { data } = props;

  const queryClient = useQueryClient();

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

  const openManageMembersDialog = async (projectId: string) => {
    setSelectedProjectId(projectId);
    setOpenMembers(true);

    await getProjectMembers(projectId).then((data) => {
      setMembers(data);
    });
  }

  const onUpdate = async (projectId: string, name?: string, description?: string) => {
    await updateProject(projectId, name, description);
    queryClient.invalidateQueries({ queryKey: ['getProjects'] });
    toast.success("Projeto atualizado com sucesso!");
  }

  const onDelete = async (projectId: string) => {
    try {
      await deleteProject(projectId);
      queryClient.invalidateQueries({ queryKey: ['getProjects'] });
      toast.success("Projeto excluído com sucesso!");
    } catch {
      toast.error("Houve algum erro, tente novamente mais tarde.");
    }
  }

  const onShare = async (projectId: string, email: string, role: string) => {
    try {
      await shareProject(projectId, email, role);
      toast.success("Convite enviado com sucesso!");
    } catch {
      toast.error("Houve algum erro, tente novamente mais tarde.");
    }
  }

  const onManageMembers = async (projectId: string, updates: { member_id: string; new_role: string; }[], deletes: {member_id: string}[]) => {
    try {
      await manageProjectMembers(projectId, updates, deletes);
      toast.success("Membros atualizados com sucesso!");
    } catch {
      toast.error("Houve algum erro, tente novamente mais tarde.");
    }
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
        initialName={data?.find(project => project.id === selectedProjectId)?.name || ""}
        initialDescription={data?.find(project => project.id === selectedProjectId)?.description || ""}
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
      <ShareProjectDialog
        open={openShare}
        setOpen={setOpenShare}
        projectId={selectedProjectId}
        onShare={onShare}
      />
      <ManageMembersDialog
        open={openMembers}
        setOpen={setOpenMembers}
        projectId={selectedProjectId}
        onManageMembers={onManageMembers}
        projectMembers={members}
      />
    </>
  );
}