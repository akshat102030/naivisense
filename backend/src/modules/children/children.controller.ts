import * as ChildService     from './children.service';
import { CreateChildSchema } from './children.schema';
import { asyncHandler }      from '../../utils/http';

export const list = asyncHandler(async (req, res) => {
  const children = await ChildService.listChildren(req.user!);
  res.json(children);
});

export const get = asyncHandler(async (req, res) => {
  const child = await ChildService.getChild(req.params.id, req.user!);
  res.json(child);
});

export const create = asyncHandler(async (req, res) => {
  const input = CreateChildSchema.parse(req.body);
  const child = await ChildService.createChild(input, req.user!);
  res.status(201).json(child);
});

export const update = asyncHandler(async (req, res) => {
  const child = await ChildService.updateChild(req.params.id, req.body, req.user!);
  res.json(child);
});

export const getSnapshot = asyncHandler(async (req, res) => {
  const snapshot = await ChildService.getSnapshot(req.params.id, req.user!);
  res.json(snapshot);
});