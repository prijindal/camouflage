import { logger } from "@repo/logger";
import { inject } from "inversify";
import { Body, Get, Path, Post, Request, Route, Security, Tags } from "tsoa";
import { User } from "../entity/user.entity";
import { CustomError } from "../errors/error";
import { AuthService } from "../service/auth.service";
import { UserService } from "../service/user.service";
import { singleton } from "../singleton";
import { SecureRequest } from "../types/auth_user";

export type UserCreationParams = Omit<
  User,
  "auth_token" | "id" | "created_at" | "updated_at" | "deleted_at"
>;

@Route("users")
@Tags("users")
@singleton(UsersController)
export class UsersController {
  constructor(
    @inject(UserService) private userService: UserService,
    @inject(AuthService) private authService: AuthService
  ) {}

  @Post("/register")
  public async register(@Body() requestBody: UserCreationParams) {
    const authToken = await this.authService.accessTokenCreate(requestBody.username);
    const user = await this.userService.create({
      ...requestBody,
      auth_token: authToken.encryptedToken,
    });
    if (user == null) {
      throw new CustomError(
        "Account creation failed",
        500,
        "There was some error creating the application and it did not return an id"
      );
    }
    return {
      username: user.username,
      token: authToken.token,
    };
  }

  @Get("/me")
  @Security("bearer")
  public async getMe(@Request() request: SecureRequest) {
    logger.info("Getting me");
    return request.loggedInUser;
  }

  @Get("/:username")
  @Security("bearer")
  public async getUser(@Path("username") username: string, @Request() request: SecureRequest) {
    const user = await this.userService.getOne(username, "username");
    if (user == null) {
      throw new CustomError("User not found", 404, "User not found");
    }
    return {
      username: user.username,
      public_key: user.public_key,
    };
  }
}