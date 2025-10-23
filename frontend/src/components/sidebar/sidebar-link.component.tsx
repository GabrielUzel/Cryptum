import Link from "next/link";
import Image from "next/image";

type SidebarLinkProps = {
  href: string;
  icon_path: string;
  label: string;
};

export default function SidebarLink(props: SidebarLinkProps) {
  const { href, icon_path, label } = props;

  return (
    <Link
      href={href}
      className="hover:bg-primary flex items-center gap-2 p-3 rounded-lg"
    >
      <Image src={icon_path} alt={label} width={24} height={24} />
      {label}
    </Link>
  );
}
