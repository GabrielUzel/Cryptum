import Image from "next/image";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import translateRole from "@/utils/translate-role";

type MemberCardProps = {
  id: string;
  name: string;
  role: string;
  isAdmin: boolean;
  markedForDelete?: boolean;
  onRoleChange: (userId: string, newRole: string) => void;
  onRemove: (userId: string, markedForDelete: boolean) => void;
};

export default function MemberCard(
  props: MemberCardProps
) {
  const { isAdmin, markedForDelete } = props;

  return (
    <Card className={`p-2 bg-card border-card ${isAdmin ? "text-gray-500" : "text-white"} ${markedForDelete ? "opacity-50 line-through" : "bg-card"}`}>
      {!isAdmin ? 
        (
          <div className="flex justify-between items-center">
            <p>{props.name}</p>
            <div className="flex gap-2 items-center">
              <Select onValueChange={(value) => props.onRoleChange(props.id, value)}>
                <SelectTrigger className="w-[120px] text-xs border-card cursor-pointer">
                  <SelectValue placeholder={translateRole(props.role)} />
                </SelectTrigger>
                <SelectContent className="bg-background border-card text-white">
                  <SelectItem className="p-2 cursor-pointer data-[highlighted]:bg-primary data-[highlighted]:text-white" value="member">Membro</SelectItem>
                  <SelectItem className="p-2 cursor-pointer data-[highlighted]:bg-primary data-[highlighted]:text-white" value="guest">Convidado</SelectItem>
                </SelectContent>
              </Select>
              <Button
                variant="ghost"
                className="!bg-card hover:!bg-card/60 hover:!text-white cursor-pointer"
                onClick={() => props.onRemove(props.id, props.markedForDelete ? false : true)}
              >
                <Image 
                  src={markedForDelete ? "undo-icon.svg" : "./user-remove-icon.svg"} 
                  alt="Remover Membro" 
                  width={16} 
                  height={16} />
              </Button>
            </div>
          </div>
        ) : (
          <div className="flex justify-between">
            <p>{props.name}</p>
            <p>(Administrador)</p>
          </div>          
        )}
    </Card>
  );
}
