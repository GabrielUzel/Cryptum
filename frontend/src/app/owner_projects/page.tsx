import SidebarComponent from "@/components/sidebar/sidebar-component";
import ProjectsTable from "@/components/projects/projects.component";
import { ClientOnly } from "@/utils/client-only.handler";

export default function OwnerProjects() {
  return (
    <div className="flex min-h-screen bg-background text-white">
      <SidebarComponent />
      <main className="flex-1 p-8">
        <ClientOnly>
          <ProjectsTable type="admin" />
        </ClientOnly>
      </main>
    </div>
  );
}
