<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class ProvisioningLinkTemplates extends Command
{
    protected $signature = 'provisioning:link-templates {--force : Replace existing paths if needed}';
    protected $description = 'Create public symlinks for provisioning template folders (predefined list)';

    public function handle(): int
    {
        $force = (bool) $this->option('force');
        $basePath = base_path();

        // Define device mappings using relative paths that will work from any installation directory
        $deviceMappings = [
            'algo/8186',
            'algo/8188',
            'algo/8189',
            'algo/8196',
            'avaya',
            'cisco/8861',
            'cisco/9861',
            'fanvil/w611w',
            'snom/C520',
            'snom/C620',
            'snom/D812',
            'snom/D815',
            'snom/D862',
            'snom/D865',
            'snom/PA1plus',
            'grandstream/wp8x6',
            'grandstream/wp826',
            'yealink/ax83h',
            'yealink/t34w',
            'yealink/w80',
        ];

        $mappings = [];
        foreach ($deviceMappings as $device) {
            $mappings[] = [
                'target' => "$basePath/resources/provisioning/$device",
                'link'   => "$basePath/public/resources/templates/provision/$device",
            ];
        }

        $successCount = 0;
        $errorCount   = 0;

        foreach ($mappings as $map) {
            $target = $map['target'];
            $link   = $map['link'];

            if (!File::exists($target)) {
                $this->error("Target does not exist: $target");
                $errorCount++;
                continue;
            }

            if (File::exists($link)) {
                if (is_link($link)) {
                    $existing = readlink($link);
                    if ($existing === $target) {
                        $this->info("Already linked: $link -> $target");
                        $successCount++;
                        continue;
                    }

                    if ($force) {
                        $this->warn("Removing old link: $link -> $existing");
                        unlink($link);
                    } else {
                        $this->warn("Link exists but points elsewhere: $link -> $existing");
                        $this->warn("Use --force to replace it.");
                        $errorCount++;
                        continue;
                    }
                } else {
                    $this->error("Path already exists and is not a symlink: $link");
                    $errorCount++;
                    continue;
                }
            }

            $linkDir = dirname($link);
            if (!File::isDirectory($linkDir)) {
                File::makeDirectory($linkDir, 0755, true);
            }

            if (@symlink($target, $link)) {
                $this->info("Created symlink: $link -> $target");
                $successCount++;
            } else {
                $this->error("Failed to create symlink: $link -> $target");
                $errorCount++;
            }
        }

        $this->newLine();
        $this->info("Finished: $successCount symlink(s) created/verified, $errorCount error(s).");

        return ($errorCount > 0) ? 1 : 0;
    }
}
