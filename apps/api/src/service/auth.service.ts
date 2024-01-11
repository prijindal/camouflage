import { logger } from "@repo/logger";
import bcrypt from "bcryptjs";
import { randomUUID } from "crypto";
import { inject } from "inversify";
import { provide } from "inversify-binding-decorators";
import jwt from "jsonwebtoken";
import { isEmpty } from "lodash";
import { UserAuthenticationError } from "../errors/auth";
import { UserService } from "../service/user.service";
import { AuthUser } from "../types/auth_user";
import { CacheService } from "./cache.service";

const JWT_SECRET = process.env["JWT_SECRET"] || "bb22aeb9-a90f-4c06-bf03-0057bcd1429f";

type AuthJwtPayload = {
  username: string;
  token: string;
};

@provide(AuthService)
export class AuthService {
  constructor(
    @inject(UserService) private userService: UserService,
    @inject(CacheService) private cacheService: CacheService
  ) {}

  accessTokenCreate = async (username: string) => {
    const token = randomUUID();
    const encryptedToken = bcrypt.hashSync(token, 10);
    return {
      encryptedToken,
      token: jwt.sign({ username: username, token: token }, JWT_SECRET),
    };
  };

  authorizationVerify = async (authorization: string | undefined) => {
    if (authorization == null || !authorization.startsWith("Bearer ")) {
      return Promise.reject({ status: "No token found" });
    }
    const jwtToken = authorization.split("Bearer ")[1];
    const userInfo = await this.accessTokenVerify(jwtToken);
    return userInfo;
  };

  // Returns user token
  private accessTokenVerify = async (token: string): Promise<AuthUser> => {
    const cacheKey = `access_token_${token}`;
    const user = this.cacheService.get<AuthUser>(cacheKey);
    if (user != null && !isEmpty(user)) {
      logger.info(`Found ${cacheKey} in cache`);
      return user;
    }
    const payload = jwt.verify(token, JWT_SECRET) as string | AuthJwtPayload;
    if (typeof payload == "string" || payload.username == null || payload.token == null) {
      throw new UserAuthenticationError(token, "Invalid JWT");
    }
    const savedUser = await this.userService.getOne(payload.username, "username");
    if (savedUser == null) {
      throw new UserAuthenticationError(payload.username, "Token not found");
    }
    const matched = bcrypt.compareSync(payload.token, savedUser.auth_token);
    if (!matched) {
      logger.error(
        `Expected token: ${payload.token} does not bcrypt match ${savedUser.auth_token}`
      );
      throw new UserAuthenticationError(payload.username, "Token not found");
    }
    logger.info(`Setting ${cacheKey} in cache`);
    this.cacheService.set<AuthUser>(cacheKey, savedUser);
    return savedUser;
  };
}
