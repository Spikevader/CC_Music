local commands = {}

commands.play_note = function(speakers, args)
    for _, sp in ipairs(speakers) do
        sp.playNote(args.instrument, args.volume, args.pitch)
    end
end

commands.play_song = function(speakers, args, loadSong)
    local song = loadSong(args.filename)
    if not song then return end
    for _, note in ipairs(song) do
        for _, sp in ipairs(speakers) do
            sp.playNote(note[1], note[2], note[3])
        end
        sleep(0.1)
    end
end

commands.stop = function() end -- placeholder

return commands
