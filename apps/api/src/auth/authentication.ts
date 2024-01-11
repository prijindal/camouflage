import { Request } from "express";
import { iocContainer } from "../ioc";
import { AuthService } from "../service/auth.service";
import { SecureRequest } from "../types/auth_user";

const API_KEY = process.env.API_KEY || "123456";
const authService = iocContainer.get(AuthService);

export async function expressAuthentication(
  request: Request,
  securityName: string,
  scopes?: string[]
): Promise<{ status?: string }> {
  if (securityName === "api_key") {
    const apiKey = request.headers["x-api-key"];
    if (apiKey && typeof apiKey === "string" && apiKey === API_KEY) {
      return Promise.resolve({});
    } else {
      return Promise.reject({ status: "No api token found" });
    }
  } else if (securityName === "bearer") {
    const authorization = request.headers.authorization;
    (request as SecureRequest).loggedInUser = await authService.authorizationVerify(authorization);
    return Promise.resolve({});
  }
  return Promise.resolve({});
}
