import Image from "next/image";
import { Button } from "../ui/button";

type SeePasswordProps = {
  isVisible: boolean;
  onToggle: (event: React.MouseEvent<HTMLButtonElement>) => void;
};

export default function SeePassword(props: SeePasswordProps) {
  return (
    <Button
      className="hover:bg-transparent hover:text-inherit cursor-pointer"
      variant={"ghost"}
      size={"icon"}
      onClick={props.onToggle}
      type="button"
      tabIndex={-1}
    >
      <Image
        src={props.isVisible ? "/eye-open-icon.svg" : "/eye-closed-icon.svg"}
        alt="Mostra senha"
        width={20}
        height={20}
      />
    </Button>
  );
}
