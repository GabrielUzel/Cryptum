export default function translateRole(role: string) {
  switch (role) {
    case "admin":
      return "Administrador";
    case "member":
      return "Editor";
    case "guest":
      return "Leitor";
    default:
      return "Unknown";
  }
}
