import { logger } from "..";

jest.spyOn(global.console, "log");

describe("@repo/logger", () => {
  it("prints a message", () => {
    logger.info("hello");
    expect(console.log).toBeCalled();
  });
});
