"use client";

import { useState, useEffect } from "react";
import { useLocalStorage } from "@uidotdev/usehooks";
import { useQueryClient } from "@tanstack/react-query";
import { useGetProjects, getProjectsQueryOptions } from '@/hooks/use-projects';
import { useGetUser } from '@/hooks/use-user';
import PaginationContainer from "@/components/@shared/pagination/pagination-container.component";
import getVisiblePages from "@/utils/pagination-pages.helper";
import ProjectsTable from "./projects-table.component";

// TODO: Adicionar funcionalidade aos botões do popover
export default function Projects() {
  const [page, setPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useLocalStorage("itemsPerPageOrders", "5");
  const queryClient = useQueryClient();
  
  const {
    data
  } = useGetProjects({
    page,
    itemsPerPage: Number(itemsPerPage)
  });

  const {
    data: user
  } = useGetUser();

  const totalPages = data?.total_pages || 0;

  useEffect(() => {
    const pagesToPrefetch = getVisiblePages(page, totalPages)
      .filter(pageObject => pageObject !== page); 

    pagesToPrefetch.forEach(page => {
      const params = { page: page, itemsPerPage: Number(itemsPerPage) };
      queryClient.prefetchQuery(getProjectsQueryOptions(params));
    });
  }, [page, totalPages, itemsPerPage, queryClient]);

  const renderTable = () => {
    if (!user) {
      return (
        <div className="flex justify-center items-center">
          <p>Você precisa estar logado para ver seus projetos.</p>
        </div>
      );
    }

    if (data?.projects.length === 0) {
      return (
        <div className="flex justify-center items-center">
          <p>Voce ainda não tem nenhum projeto, crie um para começar a produzir</p>
        </div>
      );
    }

    return (
      <div className="flex flex-col gap-5">
        <ProjectsTable data={data?.projects} />
        <PaginationContainer page={page} totalPages={totalPages} setPage={setPage} itemsPerPage={itemsPerPage} setItemsPerPage={setItemsPerPage}/>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-2">
        <h1 className="text-2xl">Lista de projetos</h1>
        <h3 className="text-sm text-gray-500">Gerencie aqui seus projetos</h3>
      </div>
      {renderTable()}
    </div>
  );
}
