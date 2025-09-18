export default function translateRole(role: string) {
  switch (role) {
    case "admin":
      return "Administrador";
    case "member":
      return "Membro";
    case "guest":
      return "Convidado";
    default:
      return "Unknown";
  }
}