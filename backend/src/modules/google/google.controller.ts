import { Request, Response } from "express";
import { getGoogleAuthUrl } from "./google.service";
import { AppError } from "../../middleware/error";
import { handleGoogleCallback } from "./google.service";
import { UserModel } from "../../models/user.model";

export async function callback(req: Request, res: Response) {
  try {
    const { code, state } = req.query;

    if (!code || !state) {
      return res.status(400).json({
        message: "Missing code/state",
      });
    }

    const user = await UserModel.findById(state);
    if (!user || user.role !== "center_head") {
      return res.status(403).json({ message: "Invalid user" });
    }


    const result = await handleGoogleCallback(
      code.toString(),

      state.toString()
    );

    res.json({
      message: "Google Calendar connected successfully",

      email: result.email,
    });
  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: "Google connection failed",
    });
  }
}

export async function auth(req: Request, res: Response) {
  const user = req.user!;

  if (user.role !== "center_head") {
    throw new AppError(
      "FORBIDDEN",
      "Only center heads can connect Google Calendar"
    );
  }

  const url = getGoogleAuthUrl(user.sub);

  res.json({
    url,
  });
}
