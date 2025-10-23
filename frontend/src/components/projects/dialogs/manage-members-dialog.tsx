import { useState, useEffect } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogClose,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import MemberCard from "./member-card.component";

type ProjectMember = {
  project_id: string;
  id: string;
  role: string;
  name: string;
};

type LocalMember = ProjectMember & {
  markedForDelete?: boolean;
};

type ManageMembersDialogProps = {
  open: boolean;
  setOpen: (open: boolean) => void;
  projectId: string | null;
  onManageMembers: (
    projectId: string,
    updates: { member_id: string; new_role: string }[],
    deletes: { member_id: string }[],
  ) => void;
  projectMembers: ProjectMember[];
};

export default function ManageMembersDialog(props: ManageMembersDialogProps) {
  const { open, setOpen, projectId, onManageMembers, projectMembers } = props;
  const [localMembers, setLocalMembers] = useState<LocalMember[]>([]);

  useEffect(() => {
    if (open) {
      setLocalMembers(projectMembers);
    }
  }, [open, projectMembers]);

  const changeRole = (userId: string, newRole: string) => {
    setLocalMembers((prev) =>
      prev.map((member) =>
        member.id === userId ? { ...member, role: newRole } : member,
      ),
    );
  };

  const removeMember = (userId: string, markedForDelete: boolean) => {
    setLocalMembers((prev) =>
      prev.map((member) =>
        member.id === userId ? { ...member, markedForDelete } : member,
      ),
    );
  };

  const handleSubmit = () => {
    if (!projectId) {
      return;
    }

    const updates = localMembers
      .filter(
        (member) =>
          member.role !== "__delete__" &&
          member.role !==
            projectMembers.find(
              (projectMember) => projectMember.id === member.id,
            )?.role,
      )
      .map((member) => ({ member_id: member.id, new_role: member.role }));

    const deletes = localMembers
      .filter((member) => member.markedForDelete)
      .map((member) => ({ member_id: member.id }));

    onManageMembers(projectId, updates, deletes);
    setOpen(false);
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent className="text-white flex flex-col gap-16 border-card">
        <div className="flex flex-col gap-8">
          <DialogHeader className="text-white">
            <DialogTitle>Gerenciar Membros</DialogTitle>
            <DialogDescription>
              Remova membros ou gerencie suas permissões.
            </DialogDescription>
          </DialogHeader>
          <div className="flex flex-col gap-2">
            {localMembers.map((member) => {
              return (
                <MemberCard
                  key={member.id}
                  id={member.id}
                  name={member.name}
                  role={member.role}
                  isAdmin={member.role === "admin"}
                  markedForDelete={member.markedForDelete}
                  onRoleChange={changeRole}
                  onRemove={removeMember}
                />
              );
            })}
          </div>
        </div>
        <DialogFooter>
          <Button
            type="button"
            onClick={() => {
              if (projectId) {
                handleSubmit();
              }
            }}
            className="!bg-primary hover:!bg-primary/60 cursor-pointer"
          >
            Atualizar
          </Button>
          <DialogClose asChild>
            <Button
              type="button"
              variant="ghost"
              className="!bg-card hover:!bg-card/60 hover:!text-white cursor-pointer"
            >
              Cancelar
            </Button>
          </DialogClose>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
