import mongoose, { Schema, Document } from "mongoose";

export interface ICenterProfile extends Document {
    user_id: mongoose.Types.ObjectId;
    center_name: string;

    smtp_credentials: {
        smtp_host: string;
        smtp_port: number;
        smtp_secure: boolean;
        smtp_user: string;
        smtp_password: string;
    };


    google_calendar?: {
        google_email: string;
        refresh_token: string;
        connected_at: Date;
    };

}


const centerProfileSchema = new Schema<ICenterProfile>({
    user_id: {
        type: Schema.Types.ObjectId,
        ref: "User",
        required: true,
        unique: true,
    },


    center_name: {
        type: String,
        required: true,
        trim: true,
    },


    smtp_credentials: {

        smtp_host: {
            type: String,
            required: true,
        },

        smtp_port: {
            type: Number,
            default: 587,
        },

        smtp_secure: {
            type: Boolean,
            default: false,
        },

        smtp_user: {
            type: String,
            required: true,
        },

        smtp_password: {
            type: String,
            required: true,
        },

    },


    google_calendar: {

        google_email: {
            type: String,
        },

        refresh_token: {
            type: String,
        },

        connected_at: {
            type: Date,
        }

    },


}, {
    timestamps: true
});


export const CenterProfileModel = mongoose.model<ICenterProfile>(
    "CenterProfile",
    centerProfileSchema
);