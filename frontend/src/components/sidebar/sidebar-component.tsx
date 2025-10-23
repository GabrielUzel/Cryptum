"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useQueryClient } from "@tanstack/react-query";
import CreateProjectDialog from "../projects/create-project-dialog.component";
import { Button } from "../ui/button";
import {
  Sidebar,
  SidebarHeader,
  SidebarContent,
  SidebarGroup,
  SidebarFooter,
  SidebarProvider,
} from "../ui/sidebar";
import SidebarLink from "./sidebar-link.component";
import SidebarUser from "./sidebar-user.component";
import { useGetUser } from "@/hooks/use-user";
import { createProject } from "@/hooks/use-projects";
import { logout } from "@/hooks/use-user";
import { toast } from "sonner";

export default function SidebarComponent() {
  const [dialogOpen, setDialogOpen] = useState(false);

  const router = useRouter();
  const queryClient = useQueryClient();
  const { data: user } = useGetUser();

  const handleCreateProjectButtonClick = (
    event: React.MouseEvent<HTMLButtonElement>,
  ) => {
    event.preventDefault();
    setDialogOpen(true);
  };

  const handleProjectCreation = async (name: string, description: string) => {
    try {
      await createProject(name, description);
      queryClient.invalidateQueries({ queryKey: ["getProjects"] });

      toast.success("Projeto criado!", {
        description: "Seu projeto foi criado com sucesso.",
      });
    } catch {
      toast.error("Erro ao criar projeto", {
        description: "Tente novamente mais tarde.",
      });
    }
  };

  const handleUserLogout = async () => {
    try {
      await logout();
      queryClient.resetQueries();
      router.replace("/");
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <SidebarProvider>
      <Sidebar className="!w-[250px] bg-background text-white [&_*]:bg-transparent border-r border-card">
        <SidebarHeader>
          <Button
            onClick={(event) => {
              handleCreateProjectButtonClick(event);
            }}
            className="cursor-pointer rounded-3xl !bg-primary hover:!bg-primary/60"
          >
            Novo Projeto
          </Button>
        </SidebarHeader>
        <SidebarContent>
          <SidebarGroup>
            <SidebarLink href="/" icon_path="house-icon.svg" label="Início" />
          </SidebarGroup>
          <SidebarGroup>
            <SidebarLink
              href="/owner_projects"
              icon_path="folder-icon.svg"
              label="Projetos próprios"
            />
          </SidebarGroup>
          <SidebarGroup>
            <SidebarLink
              href="/shared_projects"
              icon_path="users-icon.svg"
              label="Compartilhados"
            />
          </SidebarGroup>
          <SidebarGroup>
            <SidebarLink
              href="/trash_bin"
              icon_path="trash-icon.svg"
              label="Lixeira"
            />
          </SidebarGroup>
        </SidebarContent>
        <SidebarFooter>
          {user ? (
            <SidebarUser name={user.name} handleUserLogout={handleUserLogout} />
          ) : (
            <SidebarLink
              href="/auth/login"
              icon_path="login-icon.svg"
              label="Entrar"
            />
          )}
        </SidebarFooter>
      </Sidebar>
      <CreateProjectDialog
        open={dialogOpen}
        setOpen={setDialogOpen}
        onCreate={handleProjectCreation}
      />
    </SidebarProvider>
  );
}
