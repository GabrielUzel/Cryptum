import Link from "next/link";
import Image from "next/image";

type ProjectMenubarProps = {
  title: string | undefined;
}

export default function ProjectMenubar(
  props: ProjectMenubarProps
) {
  const { title } = props;

  return (
    <div className="bg-card relative flex items-center p-4">
      <Link href="/" className="absolute left-4 p-2 hover:bg-background rounded-sm">
        <Image 
          src="/left-icon.svg"
          alt="Go back"
          width={20}
          height={20}
        />
      </Link>
      <h1 className="mx-auto text-center">{title}</h1>
    </div>
  );
} 