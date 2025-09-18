import { ProjectsGateway } from '@/api/projects/projects.gateway';
import { useQuery } from '@tanstack/react-query'; 

const projectsGateway = new ProjectsGateway();

type GetProjectsParams = {
  page: number;
  itemsPerPage: number;
}

const fetchProjects = async (params: GetProjectsParams) => {
  const { page, itemsPerPage } = params;

  try {
    const data = await projectsGateway.getProjects(page, itemsPerPage);

    return data;
  } catch (error) {
    throw error;
  }
};

export const getProjectsQueryOptions = (params: GetProjectsParams) => {
  return {
    queryKey: ['getProjects', params], 
    queryFn: () => fetchProjects(params), 
    retry: false,
    refetchInterval: 30000,
    refetchOnWindowFocus: false,
  };
};

export const useGetProjects = (params: GetProjectsParams) => {
  return useQuery(getProjectsQueryOptions(params));
}

export const useGetAdminProjects = () => {
  return useQuery({
    queryKey: ['getAdminProjects'], 
      queryFn: async () => {
      try {
        const data = await projectsGateway.getAdminProjects();
        return data;
      } catch (error) {
        throw error;
      }
    }, 
  });
}

export const useGetSharedProjects = () => {
  return useQuery({
    queryKey: ['getSharedProjects'], 
      queryFn: async () => {
      try {
        const data = await projectsGateway.getSharedProjects();
        return data;
      } catch (error) {
        throw error;
      }
    }, 
  });
}

export const createProject = async (name: string, description: string) => {
  try {
    const data = await projectsGateway.createProject(name, description);
    return data;
  } catch (error) {
    throw error;
  }
}

export const updateProject = async (projectId: string, name?: string, description?: string) => {
  try {
    const data = await projectsGateway.updateProject(projectId, name, description);
    return data;
  } catch (error) {
    throw error;
  }
}

export const deleteProject = async (projectId: string) => {
  try {
    const data = await projectsGateway.deleteProject(projectId);
    return data;
  } catch (error) {
    throw error;
  }
}