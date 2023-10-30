export interface DbLogEmail {
  source: string
  version: string
  locationHash: string
  locationName: string
  createdAt: Date
  computerId: string
  messages: DbLogMessage[]
  ttl?: number
}

export interface DbLogMessage {
  level: string
  type: string
  backupType: string
  message: string
}