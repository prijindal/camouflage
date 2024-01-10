import { Request } from "express";
import { SecureRequest } from "../types/auth_user";
import { iocContainer } from "../ioc";
import { AuthService } from "../service/auth.service";

const API_KEY = process.env.API_KEY || "123456";

export async function expressAuthentication(
  request: Request,
  securityName: string,
  scopes?: string[]
): Promise<{ status?: string }> {
  const authService = iocContainer.get(AuthService);
  if (securityName === "api_key") {
    const apiKey = request.headers["x-api-key"];
    if (apiKey && typeof apiKey === "string" && apiKey === API_KEY) {
      return Promise.resolve({});
    } else {
      return Promise.reject({ status: "No api token found" });
    }
  } else if (securityName === "bearer") {
    const authorization = request.headers.authorization;
    if (authorization == null || !authorization.startsWith("Bearer ")) {
      return Promise.reject({ status: "No token found" });
    }
    const jwtToken = authorization.split("Bearer ")[1];
    const userInfo = await authService.accessTokenVerify(jwtToken);
    (request as SecureRequest).loggedInUser = {
      username: userInfo.username,
      public_key: userInfo.public_key,
    };
    return Promise.resolve({});
  }
  return Promise.resolve({});
}
